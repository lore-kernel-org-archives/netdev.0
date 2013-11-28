From: David Chang <dchang@suse.com>
Subject: Re: [PATCH net] r8169: check ALDPS bit and disable it if enabled
 forthe 8168g
Date: Thu, 28 Nov 2013 14:22:57 +0800
Message-ID: <20131128062257.GB9297@linux-g7tt.site>
References: <1385538516-32104-1-git-send-email-dchang@suse.com>
 <103D217663F345E1877FB05AC93E3CFF@realtek.com.tw>
 <20131128042904.GA9297@linux-g7tt.site>
 <39CC8E82FCD4479EAB9EDB7D7F708397@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "'David S. Miller'" <davem@davemloft.net>,
	'Francois Romieu' <romieu@fr.zoreil.com>, jlee@suse.com,
	'nic_swsd' <nic_swsd@realtek.com>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:37017 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093Ab3K1GYO (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:0:0>);
	Thu, 28 Nov 2013 01:24:14 -0500
Content-Disposition: inline
In-Reply-To: <39CC8E82FCD4479EAB9EDB7D7F708397@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 28, 2013 at 01:28:08PM +0800, hayeswang wrote:
>  David Chang [mailto:dchang@suse.com] 
> > Sent: Thursday, November 28, 2013 12:29 PM
> > To: Hayeswang
> > Cc: netdev@vger.kernel.org; 'David S. Miller'; 'Francois 
> > Romieu'; jlee@suse.com; nic_swsd
> > Subject: Re: [PATCH net] r8169: check ALDPS bit and disable 
> > it if enabled forthe 8168g
> [...]
> > > You have to delay at least 10 ms after disable it.
> > > This makes sure the hw completes the action.
> > >  
> > 
> > Thanks for your comment. 
> > I'd add a delay time and send the v2 version.
> 
> Excuse me. Our engineers have different opinions about the delay.
> I would comfirm it first.
>  
OK! I'd wait until the final result, thanks!

Regards,
David
> Best Regards,
> Hayes
> 
> 
