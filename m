From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [net-next 08/11] e1000e: add Receive Packet Steering (RPS)
 support
Date: Tue, 3 Jan 2012 20:28:37 +0000
Message-ID: <804857E1F29AAC47BF68C404FC60A18402A7BC@ORSMSX102.amr.corp.intel.com>
References: <1325618356-2655-9-git-send-email-jeffrey.t.kirsher@intel.com>
	<20120103.150936.572765552893657192.davem@davemloft.net>
	<804857E1F29AAC47BF68C404FC60A1840292A5@ORSMSX102.amr.corp.intel.com>
 <20120103.152739.1456113375065412910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63507 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752502Ab2ACU2j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 15:28:39 -0500
In-Reply-To: <20120103.152739.1456113375065412910.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Tuesday, January 03, 2012 12:28 PM
>To: Allan, Bruce W
>Cc: Kirsher, Jeffrey T; netdev@vger.kernel.org; gospo@redhat.com;
>sassmann@redhat.com
>Subject: Re: [net-next 08/11] e1000e: add Receive Packet Steering (RPS) support
>
>From: "Allan, Bruce W" <bruce.w.allan@intel.com>
>Date: Tue, 3 Jan 2012 20:16:44 +0000
>
>> I was under the impression from recently accepted patches that the preferred
>> method for log/error message strings was to keep them as a single string
>> (rather than broken across multiple lines) for easy searching.  Is that not
>> the case here?
>>
>>>From ./Documentation/CodingStyle..."never break user-visible strings such as
>> printk messages, because that breaks the ability to grep for them."
>>
>> Do you still want this change?
>
>Fair enough, I rescind my request and this patch is fine as-is.

Okay, thanks Dave.

Bruce.
