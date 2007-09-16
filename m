From: "L F" <lfabio.linux@gmail.com>
Subject: Re: e1000 driver and samba
Date: Sun, 16 Sep 2007 00:07:29 -0400
Message-ID: <780b6f780709152107j7ae44c4fg7c27420664ff0157@mail.gmail.com>
References: <780b6f780709131904j41148fb4p827e87530b15d6e9@mail.gmail.com>
	 <46EAC25B.2060404@intel.com>
	 <780b6f780709141140l1fd586c9p2aa8efe6ed803d38@mail.gmail.com>
	 <46EAF644.1040006@intel.com> <46EC1A00.2000304@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "James Chapman" <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:1678 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbXIPEHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 00:07:30 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1533147wah
        for <netdev@vger.kernel.org>; Sat, 15 Sep 2007 21:07:29 -0700 (PDT)
In-Reply-To: <46EC1A00.2000304@katalix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/15/07, James Chapman <jchapman@katalix.com> wrote:
> Are these long frames expected in your network? What is the MTU of the
> transmitting clients? Perhaps this might explain why reads work (because
> data is coming from the Linux box so the packets have smaller MTU) while
> writes cause delays or packet loss because the clients are sending long
> frames which are getting fragmented?
I doublechecked in any case. All machines on the network have the
default XP MTU of 1500. So does the linux machine. I therefore foresee
no problem there.

> James Chapman

LF
