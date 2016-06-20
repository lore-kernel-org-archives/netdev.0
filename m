From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: rcu locking issue in mpls output code?
Date: Mon, 20 Jun 2016 10:38:39 -0600
Message-ID: <e84c7422-c688-faec-54ac-e0a5607d6c3d@cumulusnetworks.com>
References: <20160620004546.GP20238@wantstofly.org>
 <8d325ab7-bc46-dd69-288a-571d56efc545@cumulusnetworks.com>
 <20160620063055.GR20238@wantstofly.org>
 <7d7097bc-ce10-d8e1-4a90-36045c7d2041@cumulusnetworks.com>
 <CAJieiUi8WX1=Yri_b8aZpP2sEkQ6CqARcX29M94Qdf4gczFDjg@mail.gmail.com>
 <20160620163317.GS20238@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Shearman <rshearma@brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35782 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753797AbcFTQjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 12:39:49 -0400
Received: by mail-pf0-f169.google.com with SMTP id c2so55792709pfa.2
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 09:38:41 -0700 (PDT)
In-Reply-To: <20160620163317.GS20238@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/20/16 10:33 AM, Lennert Buytenhek wrote:
> OK, patch coming up.  Thanks!

can you build a kernel with rcu debugging enabled as well and run it 
through your tests?

Thanks,
