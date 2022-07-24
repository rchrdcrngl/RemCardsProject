package com.example.reminders;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;

public class adapterCard extends RecyclerView.Adapter<adapterCard.CardViewHolder>{
    private ArrayList<cardrem> remcard;
    private OnItemClickListener mListener;

    public interface OnItemClickListener {
        void onItemClick(int position);
        void onChangeStatus(int position);
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        mListener = listener;
    }

    public static class CardViewHolder extends RecyclerView.ViewHolder {
        public ImageView mImageView;
        public TextView sbjCode;
        public TextView tskDesc;
        public TextView tskDate;
        public TextView tskLvl;
        public LinearLayout colorCar;


        public CardViewHolder(View itemView, final OnItemClickListener listener) {
            super(itemView);
            mImageView = itemView.findViewById(R.id.levelsign);
            sbjCode = itemView.findViewById(R.id.subject_code);
            tskDesc = itemView.findViewById(R.id.description);
            tskDate = itemView.findViewById(R.id.date);
            colorCar = itemView.findViewById(R.id.cardClr);


            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if(listener != null){
                        int position = getAdapterPosition();
                        if (position != RecyclerView.NO_POSITION){
                            listener.onItemClick(position);
                        }
                    }
                }
            });

            mImageView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(listener != null){
                        int position = getAdapterPosition();
                        if (position != RecyclerView.NO_POSITION){
                            listener.onChangeStatus(position);
                        }
                    }
                }
            });
        }

        public void setsbjCode(String string) {
            sbjCode.setText(string);
        }
        public void settskDesc(String string) {
            tskDesc.setText(string);
        }
        public void settskDate(String string) {
            tskDesc.setText(string);
        }
        public void setTskLvl(String string) {
            sbjCode.setText(string);
        }




    }


    public adapterCard(ArrayList<cardrem> x){
        remcard = x;

    }

    @NonNull
    @Override
    public CardViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.cardrem, parent, false);
        CardViewHolder cvh = new CardViewHolder(v, mListener);
        return cvh;

    }

    @Override
    public void onBindViewHolder(CardViewHolder holder, int position) {
        cardrem currentItem =remcard.get(position);
        holder.mImageView.setImageResource(currentItem.getImgRsc());
        holder.sbjCode.setText(currentItem.getsbjCode());
        holder.tskDesc.setText(currentItem.gettskDesc());
        holder.tskDate.setText(currentItem.getTskDate());
        holder.colorCar.setBackgroundResource(currentItem.getbg());

    }

    @Override
    public int getItemCount() {
        return remcard.size();
    }
}
