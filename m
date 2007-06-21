From: jamal <hadi@cyberus.ca>
Subject: Re: FSCKED clock sources WAS(Re: [WIP][PATCHES] Network xmit
	batching
Date: Thu, 21 Jun 2007 12:08:19 -0400
Message-ID: <1182442099.5017.51.camel@localhost>
References: <20070619140038.GA13629@2ka.mipt.ru>
	 <1182270529.4968.73.camel@localhost>
	 <18040.5105.715624.286924@robur.slu.se>
	 <20070619.152801.99185860.davem@davemloft.net>
	 <1182441257.5017.48.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, johnpol@2ka.mipt.ru,
	krkumar2@in.ibm.com, gaagaan@gmail.com, netdev@vger.kernel.org,
	rick.jones2@hp.com, sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.226]:44448 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303AbXFUQIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 12:08:23 -0400
Received: by wx-out-0506.google.com with SMTP id t15so556842wxc
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2007 09:08:23 -0700 (PDT)
In-Reply-To: <1182441257.5017.48.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-21-06 at 11:54 -0400, jamal wrote:

> The summary is: Batching always is better, jiffies is always the better
> clock source (and who would have thunk,eh? Opteron kicks a Xeons ass).

The results in the table for opteron and xeon are swapped when
cutnpasting from a larger test result. So Opteron is the one with better
results.
In any case - off for the day over here.

cheers,
jamal


