From: Andrej Manduch <amanduch@gmail.com>
Subject: Re: [PATCH] sctp: Simplify and make the function sctp_assoc_lookup_laddr
 bool
Date: Fri, 05 Jun 2015 17:56:33 -0400
Message-ID: <55721B11.9020303@gmail.com>
References: <1433526062-2364-1-git-send-email-xerofoify@gmail.com> <20150605191610.GC29877@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>,
	Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:34156 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbbFEV4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 17:56:37 -0400
In-Reply-To: <20150605191610.GC29877@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Neil,

  I would like to kindly ask you to always put full patch in reply when
you are replying to Nicks patch. Because he's banned from vger and only
people on cc are able to see his patches and this is only way for rest
of us to see what is in his patch.

  Thanks.

On 06/05/2015 03:16 PM, Neil Horman wrote:
>> This makes the function sctp_assoc_lookup_laddr bool due to it
>> only returning either one or zero as its return value. Further
>> more this function can we simplified to return the if statement
>> as part of this function directly and thus remove the no longer
>> required if statement due to this function now being declared
>> as bool.
>> 
>> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>

-- 
Kind regards,
b.
