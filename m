From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Re: [PATCH 1/2] Use VPI.VCI notation uniformly.
Date: Wed, 30 Mar 2011 17:17:58 -0600
Message-ID: <4D93BA26.2010405@redfish-solutions.com>
References: <1301525787-28447-1-git-send-email-philipp_subx@redfish-solutions.com> <20110330.160358.55865087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:41831 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753613Ab1C3XSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 19:18:00 -0400
In-Reply-To: <20110330.160358.55865087.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/30/11 5:03 PM, David Miller wrote:
> From: Philip Prindeville <philipp_subx@redfish-solutions.com>
> Date: Wed, 30 Mar 2011 16:56:27 -0600
>
>> From: Philip A. Prindeville <philipp@redfish-solutions.com>
>>
>> Use VPI.VCI notation consistently throughout the module. This is the
>> one remaining place where the VCI is used before the VPI in any output.
>>
>> Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>
>> ---
>>  drivers/atm/solos-pci.c |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
> Why do your subject lines not have an appropriate prefix?
>
> How will someone scanning the commit header lines in the tree know
> that this is a change to the solos-pci driver unless you prefix
> them with "solos-pci: " or similar?

It was an oversight.  Want me to resubmit?

