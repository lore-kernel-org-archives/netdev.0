From: Stefano Salsano <stefano.salsano@uniroma2.it>
Subject: Re: [PATCH] netem/iproute2 solving correlated loss issues [2/5]
Date: Sat, 19 Dec 2009 00:49:51 +0100
Message-ID: <4B2C151F.7080904@uniroma2.it>
References: <4B2B5A26.8050400@uniroma2.it>	<4B2B6676.301@yahoo.it> <20091218093605.76903fe5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Fabio Ludovici <fabio.ludovici@yahoo.it>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.uniroma2.it ([160.80.6.16]:48950 "EHLO smtp.uniroma2.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755499AbZLRXt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2009 18:49:57 -0500
In-Reply-To: <20091218093605.76903fe5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Fri, 18 Dec 2009 12:24:38 +0100
> Fabio Ludovici <fabio.ludovici@yahoo.it> wrote:
>> patch 2/5 : linux-2.6.32/net/sched/sch_netem.c
> 
> Could you send with official signed-off-by line please?

we will resend this (and the other related patches) with the 
signed-off-by line, sorry !

> Need some style work to match kernel coding style (not a big issue).
> And it would be helpful to put in more descriptive variable names
> or documentation. But I will try and address these and resubmit,
> keeping you as original author.

we'll try to address some of the issues in the resubmission of the patch

you are very welcome to add yourself as author if you wish, in case you 
will help us with styling/renaming/documentation !

thank you
Stefano & Fabio
-- 
*******************************************************************
Stefano Salsano
Dipartimento Ingegneria Elettronica
Universita' di Roma "Tor Vergata"
Via del Politecnico, 1 - 00133 Roma - ITALY

http://netgroup.uniroma2.it/Stefano_Salsano/

E-mail  : stefano.salsano@uniroma2.it
Cell.   : +39 320 4307310
Office  : (Tel.) +39 06 72597770  (Fax.) +39 06 72597435
*******************************************************************
