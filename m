From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net] be2net: Fix to avoid hardware workaround when not
 needed
Date: Wed, 17 Jul 2013 09:01:54 -0700
Message-ID: <51E6BFF2.2030000@hp.com>
References: <458bdd84-53ce-489e-b134-f435c5fd6a50@CMEXHTCAS2.ad.emulex.com> <20130716.130358.711125572475101678.davem@davemloft.net> <9D1F9FE58F08ED47AA451ABB038550E936D5179F@CMEXMB1.ad.emulex.com> <20130716.220137.1485690004462887417.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sarveshwar.Bandi@Emulex.Com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:31040 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755557Ab3GQQB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 12:01:56 -0400
In-Reply-To: <20130716.220137.1485690004462887417.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/16/2013 10:01 PM, David Miller wrote:
> From: "Bandi, Sarveshwar" <Sarveshwar.Bandi@Emulex.Com>
> Date: Wed, 17 Jul 2013 03:03:52 +0000
>
>>    Please queue up this patch for 3.10 stable.
>
> Done.

Huzzah! (I was hitting this bug...)

rick jones
