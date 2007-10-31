From: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>
Subject: RE: [PATCH 10/14 v2] nes: eeprom and phy routines
Date: Wed, 31 Oct 2007 16:47:40 -0500
Message-ID: <5E701717F2B2ED4EA60F87C8AA57B7CC0793936C@venom2>
References: <200710192021.l9JKLGFU021817@neteffect.com> <ada1wbbghe2.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <ewg@lists.openfabrics.org>, <general@lists.openfabrics.org>,
	<netdev@vger.kernel.org>
To: "Roland Dreier" <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.neteffect.com ([204.57.75.68]:18595 "EHLO
	mail2.neteffect.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754760AbXJaVrn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 17:47:43 -0400
Content-class: urn:content-classes:message
In-Reply-To: <ada1wbbghe2.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>  > +/*
>  > +"Everything you wanted to know about CRC algorithms, but 
> were afraid to ask
>  > + for fear that errors in your understanding might be 
> detected." Version  : 3.
> 
> etc etc... can all this be replaced with what's in lib/crc32.c?  (I
> hope so)

Replacing this code is already in the works.

Glenn.

> 
>  - R.
> 
