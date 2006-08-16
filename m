From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Packet Corruption Support
Date: Wed, 16 Aug 2006 15:54:39 -0700
Message-ID: <44E3A22F.8030401@hp.com>
References: <44E3A132.7090302@aston.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:33231 "EHLO palrel13.hp.com")
	by vger.kernel.org with ESMTP id S932315AbWHPWy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 18:54:56 -0400
To: Ritesh Taank <taankr@aston.ac.uk>
In-Reply-To: <44E3A132.7090302@aston.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ritesh Taank wrote:
> Hi there,
> 
> I am currently using netem that has been packaged with my linux kernel 
> 2.6.17 (as part of the Knoppix 5.0.1 Boot CD), and the 'corrupt' 
> parameter is not being recognised as a valid argument.
> 
> Having read many posts online, it appears that the Packet Corruption 
> feature should be supported from kernel versions 2.6.16 onwards.

I would think that if run on an end system at least, trying to corrupt 
packets with CKO enabled on a NIC might be, well, difficult.  Or does 
netem disable CKO?

rick jones
