From: Jon Grimm <jgrimm2@us.ibm.com>
Subject: Re: [Lksctp-developers] [PATCH] subset of RFC2553
Date: Wed, 12 Feb 2003 20:24:22 -0600
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3E4B01D6.3050604@us.ibm.com>
References: <1045091741.8858.320.camel@w-bwa1.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, lksctp-developers@lists.sourceforge.net,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Bruce Allan <bwa@us.ibm.com>
List-Id: netdev.vger.kernel.org

Bruce Allan wrote:
 > and moves the definition of struct sockaddr_storage from the
 > SCTP code to a common IPv6 header file. These changes will assist in
 > making certain networking kernel code portable across multiple address
 > families.

Hi Bruce,
	I don't have any issue with moving sockaddr_storage out of lksctp 
headers (though I don't own the decision to move them into the core 
headers).

Thanks,
Jon Grimm

