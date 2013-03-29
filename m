From: hayeswang <hayeswang@realtek.com>
Subject: RE: r8169 auto speed down issue
Date: Fri, 29 Mar 2013 10:11:57 +0800
Message-ID: <83FC3118294143DC81063B29EF570FC1@realtek.com.tw>
References: <4EECA12DD88643FD9006350514D96C8E@realtek.com.tw> <20130328231955.GA26182@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<bowgotsai@google.com>, 'Ryankao' <ryankao@realtek.com>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130328231955.GA26182@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]
> Your description suggests that testing against the link 
> partner ability
> to work at 10M instead of testing for tp->link_ok could be 
> good enough.
> 
> Does it make sense ?
> 

Furthermore, should it not speed down without linking, even though the cable
would be plugged after suspending or shutdowning?

Best Regards,
Hayes
