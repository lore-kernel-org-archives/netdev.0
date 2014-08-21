From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 3/4] r8152: remove clear_bp function
Date: Thu, 21 Aug 2014 02:12:48 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2515BB5@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-16-Taiwan-albertk@realtek.com>
 <1394712342-15778-19-Taiwan-albertk@realtek.com>
 <201408210131.s7L1VuAJ031162@rtits1.realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201408210131.s7L1VuAJ031162@rtits1.realtek.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com] 
> Sent: Wednesday, August 20, 2014 8:01 PM
> To: Hayes Wang; netdev@vger.kernel.org
> Cc: nic_swsd; linux-kernel@vger.kernel.org; linux-usb@vger.kernel.org
> Subject: Re: [PATCH net-next 3/4] r8152: remove clear_bp function
[...]
> >   	r8152b_disable_aldps(tp);
> >
> > -	rtl_clear_bp(tp);
> >
> 
>     Why leave 2 empty lines? One is enough.

The next patch would use another fucntion at the
same location. I skip removing the empty line and
re-adding it again. Is that better to do so? I would
resend the patches if the answer is yes.
 
Best Regards,
Hayes
