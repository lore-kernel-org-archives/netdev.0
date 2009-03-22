From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: Status update on Sun Neptune 10Gbit fibre using the NIU-driver.
Date: Sun, 22 Mar 2009 19:17:08 +0100
Message-ID: <49C680A4.5020706@krogh.cc>
References: <49C600CE.70704@krogh.cc> <49C65AFC.3080300@cosmosbay.com> <49C67CF4.5080202@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:49612 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751134AbZCVSRG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Mar 2009 14:17:06 -0400
In-Reply-To: <49C67CF4.5080202@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Krogh wrote:
> Eric Dumazet wrote:
>> Also, testing 2.6.29 could be interesting, since UDP receive
>> path doesnt need to use a global rwlock anymore.
> 
> ... That gained yet another 100MB/s.. now peaking out around 1050-1060MB/s.

Am I wrong thinking that theoretical max should be around 1150-1200MB/s ?

-- 
Jesper
