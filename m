From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek source
Date: Thu, 27 Mar 2008 22:50:58 +0100
Message-ID: <20080327215058.GB19329@electric-eye.fr.zoreil.com>
References: <20080323230045.GA16510@vsuchard.aplis.com> <20080324131824.GA18032@electric-eye.fr.zoreil.com> <20080324233910.GB16510@vsuchard.aplis.com> <20080326224345.GA19954@electric-eye.fr.zoreil.com> <20080327135844.GR16510@vsuchard.aplis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vlastislav SUCHARDA <vsucharda@aplis.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37514 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757046AbYC0WLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 18:11:40 -0400
Content-Disposition: inline
In-Reply-To: <20080327135844.GR16510@vsuchard.aplis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlastislav SUCHARDA <vsucharda@aplis.cz> :
[...]
> The main point for me is having right working module in
> 2.6.18-53.1.14.el5.centos.plus kernel (CentOS 5.1).

(back to list as it may be of general interest)

Try http://userweb.kernel.org/~romieu/r8169/2.6.18/stable-4/to-2.6.24/

It contains a patch for the r8169 driver which should apply to your
2.6.18.4 based kernel and turn its r8169 driver into something closer
to 2.6.24. The kit contains a stack of incremental patches too if you
are curious.

I have fixed some rejects, checked that everything compiles at each
step but the patch is otherwise untested. Use at your own risk.

Feedback welcome.

-- 
Ueimor
