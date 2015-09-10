From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [pve-devel] bridge vlan range, kernel 4.1 : "message truncated"
 warning when too much vlans defined
Date: Thu, 10 Sep 2015 15:26:30 -0700
Message-ID: <55F20396.9090505@cumulusnetworks.com>
References: <1522237479.23555412.1438194289391.JavaMail.zimbra@oxygem.tv> <E4CD12F19ABA0C4D8729E087A761DC350F536639@ORSMSX101.amr.corp.intel.com> <999679133.23642075.1438234304221.JavaMail.zimbra@oxygem.tv> <972878625.39892449.1441867226052.JavaMail.zimbra@oxygem.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Arad, Ronen" <ronen.arad@intel.com>,
	netdev <netdev@vger.kernel.org>,
	Rami Rosen <rami.rosen@intel.com>
To: Alexandre DERUMIER <aderumier@odiso.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33231 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114AbbIJW0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 18:26:31 -0400
Received: by pacex6 with SMTP id ex6so54984791pac.0
        for <netdev@vger.kernel.org>; Thu, 10 Sep 2015 15:26:31 -0700 (PDT)
In-Reply-To: <972878625.39892449.1441867226052.JavaMail.zimbra@oxygem.tv>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 9/9/15, 11:40 PM, Alexandre DERUMIER wrote:
> Hi,
>
> This still not fixed in iproute 4.2.
>
> Is they any plan to increase the rtnl_dump_filter buffer size soon ?
>
Instead of increasing the default size, it would be nicer if this was 
configurable for iproute2 (I haven't looked yet).
