From: "Jongsung Kim" <neidhard.kim@lge.com>
Subject: RE: net: phy: realtek: add rtl8201f driver
Date: Fri, 10 May 2013 12:44:42 +0900
Message-ID: <010f01ce4d30$b500caa0$1f025fe0$@lge.com>
References: <201305081910.27203.neidhard.kim@lge.com> <518A7284.4000504@cogentembedded.com> <008d01ce4c5d$cfd36410$6f7a2c30$@lge.com> <518BD5CF.8040502@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <peppe.cavallaro@st.com>,
	<chohnstaedt@innominate.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "'Sergei Shtylyov'" <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <518BD5CF.8040502@cogentembedded.com>
Content-Language: ko
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> :
>> Agreed. I just thought it's better to make it similar to the 
>> rtl821x_ack_interrupt.
>
>    Ah, then you may leave this code as is.
>
>> Then, may I make shorter the rtl821x_ack_interrupt as well as 
>> rtl8201f_ack_interrupt?
>
>    In a separate patch, if you wish.
>

Thank you for your comment.
