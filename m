From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Constrain UFO fragment sizes to multiples of 8 bytes
Date: Thu, 21 Jul 2011 21:32:02 -0700 (PDT)
Message-ID: <20110721.213202.1986895688606533949.davem@davemloft.net>
References: <1311124953-32159-1-git-send-email-wsommerfeld@google.com>
	<CANP3RGdBTXf1+mwJXEW7Nv_jENE_SP00h2W4d05Ki6JT-5LpvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: wsommerfeld@google.com, netdev@vger.kernel.org, therbert@google.com
To: maze@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48059 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085Ab1GVEcE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 00:32:04 -0400
In-Reply-To: <CANP3RGdBTXf1+mwJXEW7Nv_jENE_SP00h2W4d05Ki6JT-5LpvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <maze@google.com>
Date: Tue, 19 Jul 2011 18:30:22 -0700

> Ack.
> This should probably make it into all manner of stable branches.

Applied and queued up for -stable.
