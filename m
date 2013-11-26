From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 Wake on Lan
Date: Wed, 27 Nov 2013 00:57:27 +0100
Message-ID: <20131126235727.GA8466@electric-eye.fr.zoreil.com>
References: <CAEv3EXFiUnfkBCiedjXUzc6MXBnP2vqNx4R3739642dGYazTwA@mail.gmail.com>
 <20131126232101.GA7508@electric-eye.fr.zoreil.com>
 <CAEv3EXFm5MrDeZLRyAZdVNoXWEGB7sU405+oM7K=o=eiAnUNPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pablo Cholaky <mrwaltercool@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:33207 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950Ab3KZX5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 18:57:30 -0500
Content-Disposition: inline
In-Reply-To: <CAEv3EXFm5MrDeZLRyAZdVNoXWEGB7sU405+oM7K=o=eiAnUNPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(please no top-posting)

Pablo Cholaky <mrwaltercool@gmail.com> :
[...]
> If kernel parameters are ugly... a on-kernel option should be bad too?

Yes.

You use runtime suspend, suspend to disk and your ethernet network device
is up, right ?

-- 
Ueimor
