From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 ethernet bonding problems
Date: Tue, 1 May 2007 23:17:54 +0200
Message-ID: <20070501211754.GB17225@electric-eye.fr.zoreil.com>
References: <9e246b4d0704180552q16b05017wd0d7041c3ce04f46@mail.gmail.com> <20070418181333.GA2261@electric-eye.fr.zoreil.com> <9e246b4d0704271353g105ecd62j4f35a6e9027ad590@mail.gmail.com> <20070427220918.GB24358@electric-eye.fr.zoreil.com> <9e246b4d0705011317t72bc9413u2b002b71ca3865e9@mail.gmail.com> <20070501204721.GB19212@electric-eye.fr.zoreil.com> <9e246b4d0705011359r208ce760yba6edda835ca67a6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tim Durack <tdurack@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58853 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423601AbXEAVSs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 17:18:48 -0400
Content-Disposition: inline
In-Reply-To: <9e246b4d0705011359r208ce760yba6edda835ca67a6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tim Durack <tdurack@gmail.com> :
> >Can you try to set the MAC address by hand with the completely patched
> >kernel (i.e. including the mac-address-change patch) ?
> 
> Yup. Works fine. The randomly changing interface order is proving to
> be a challenge!

udev should be your friend to do a BUS/ID based rename.

-- 
Ueimor

Anybody got a battery for my Ultra 10 ?
