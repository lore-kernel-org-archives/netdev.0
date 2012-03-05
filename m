From: Shiraz Hashim <shiraz.hashim@st.com>
Subject: Re: [PATCH 4/6] stmmac: Update stmmac descriptor checks for stmmac
 core prior to Rev-3.5.
Date: Mon, 5 Mar 2012 09:31:25 +0530
Message-ID: <20120305040125.GB7045@localhost.localdomain>
References: <1330692928-30330-3-git-send-email-deepak.sikri@st.com>
 <1330692928-30330-4-git-send-email-deepak.sikri@st.com>
 <1330692928-30330-5-git-send-email-deepak.sikri@st.com>
 <20120304.205155.650947216183181836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Deepak SIKRI <deepak.sikri@st.com>,
	Peppe CAVALLARO <peppe.cavallaro@st.com>,
	spear-devel <spear-devel@list.st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:45358 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755644Ab2CEECB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 23:02:01 -0500
Content-Disposition: inline
In-Reply-To: <20120304.205155.650947216183181836.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

On Mon, Mar 05, 2012 at 09:51:55AM +0800, David Miller wrote:
> From: Deepak Sikri <deepak.sikri@st.com>
> > +			/*
> > +			 * The type-1 checksume offload engines append
> > +			 * the checksum at the end of frame, and the
> 
> 	/* Format comments
> 	 * like this.
> 	 */
> 
> 	/*
> 	 * Not
> 	 * like this.
> 	 */

Linux Documentation/CodingStyle mentions following about comments in
chapter 8.

The preferred style for long (multi-line) comments is: 

        /*  
         * This is the preferred style for multi-line
         * comments in the Linux kernel source code.
         * Please use it consistently.
         *   
         * Description:  A column of asterisks on the left side,
         * with beginning and ending almost-blank lines.
         */  

Are we missing something ?

--
regards
Shiraz
