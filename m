From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: ksoftirqd uses 99% CPU triggered by network traffic (maybe
 RLT-8139 related)
Date: Tue, 27 Jul 2004 13:10:37 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <16646.14381.740376.204381@robur.slu.se>
References: <16645.34772.760879.146784@robur.slu.se>
	<Pine.LNX.4.44.0407270304570.11416-100000@silmu.st.jyu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Francois Romieu <romieu@fr.zoreil.com>,
	H?ctor Mart?n <hector@marcansoft.com>,
	Linux-Kernel <linux-kernel@vger.kernel.org>, <akpm@osdl.org>,
	<netdev@oss.sgi.com>, <brad@brad-x.com>, <shemminger@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263743AbUG0LK7@vger.kernel.org>
To: Pasi Sjoholm <ptsjohol@cc.jyu.fi>
In-Reply-To: <Pine.LNX.4.44.0407270304570.11416-100000@silmu.st.jyu.fi>
List-Id: netdev.vger.kernel.org


Pasi Sjoholm writes:

 > First run:
 > timestamp diff = 0, maxlat = 4581159

 Yes you starved your user apps for ~5 sec. 
 
 Any idea where your load comes from? Pure NFS network load cannot be hard.
 
 Cheers.
						--ro
