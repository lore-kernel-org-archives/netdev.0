From: Patrick McHardy <kaber@trash.net>
Subject: Re: AW: AW: AW: Problem receiving multicast with kernel.2.6.24, REAL
	solution
Date: Tue, 19 Feb 2008 15:56:07 +0100
Message-ID: <47BAEE07.1080603@trash.net>
References: <BA41E8A07B73A041948C2E3A4EF6239D062F1B@av-digital-exch.avdigital.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Reither Robert <Robert.Reither@av-digital.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:23026 "EHLO
	viefep17-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756248AbYBSO40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 09:56:26 -0500
Received: from edge03 ([192.168.13.238]) by viefep17-int.chello.at
          (InterMail vM.7.08.02.00 201-2186-121-20061213) with ESMTP
          id <20080219145622.PKGH27032.viefep17-int.chello.at@edge03>
          for <netdev@vger.kernel.org>; Tue, 19 Feb 2008 15:56:22 +0100
In-Reply-To: <BA41E8A07B73A041948C2E3A4EF6239D062F1B@av-digital-exch.avdigital.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reither Robert wrote:
> Visit AVD on prolight+sound in Frankfurt from 12.-15. March 2008 - Hall 8.0, Stand G16
> ________________________________________________________________________
> 
> 
> 
> Hurray, your patch does the trick for me !!!
> 
> Now join/leave und receiving of multicasts work like it should !!
> 
> May i kiss you Patrick, this saves my week ;-)

The credit goes to Jorge Boncompte, I only broke it :|

> Hope we see a minor kernel release with this patch very soon ...

Yes, I'll send it to -stable as soon as it hits upstream.

