From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: add vlan id to mdb notifications
Date: Fri, 28 Nov 2014 02:18:52 -0800
Message-ID: <54784C0C.30409@cumulusnetworks.com>
References: <1417010013-31454-1-git-send-email-roopa@cumulusnetworks.com> <20141126105614.6a42d697@urahara> <54763AA6.4000804@cumulusnetworks.com> <20141126215327.GC13786@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	vyasevich@gmail.com, netdev@vger.kernel.org,
	wkok@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, sashok@cumulusnetworks.com,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:53143 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbaK1KS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 05:18:57 -0500
In-Reply-To: <20141126215327.GC13786@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/14, 1:53 PM, Thomas Graf wrote:
> On 11/26/14 at 12:40pm, Roopa Prabhu wrote:
>> I have always wondered, if binary netlink attributes have this restriction,
>> they should be discouraged. especially when the other extensible option is
>> to add them as a separate netlink attribute.
> This is pretty much exactly the reason why attributes have been
> introduced ;-)

thanks for confirming that thomas :). Will resubmit the patch with vlan 
information as a separate attribute.
