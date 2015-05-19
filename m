From: Joao Martins <Joao.Martins@neclab.eu>
Subject: Re: [Xen-devel] [RFC PATCH 11/13] xen-netfront: feature-persistent
 xenbus support
Date: Tue, 19 May 2015 10:19:35 +0000
Message-ID: <ED338FEB-F998-4AFF-A6A0-0DBAC87200E6@neclab.eu>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-12-git-send-email-joao.martins@neclab.eu>
 <555A0A95.20409@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wei.liu2@citrix.com" <wei.liu2@citrix.com>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.neclab.eu ([195.37.70.40]:55446 "EHLO mailer1.neclab.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753139AbbESKTs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 06:19:48 -0400
In-Reply-To: <555A0A95.20409@citrix.com>
Content-Language: en-US
Content-ID: <E15A8922AAED2C47A76D5D4D06239013@office.hd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 18 May 2015, at 17:51, David Vrabel <david.vrabel@citrix.com> wrote:
> On 12/05/15 18:18, Joao Martins wrote:
>> "feature-persistent" check on xenbus for persistent grants
>> support on the backend.
> 
> You can't expose/check for this feature until you actually support it.
> This should probably be the last patch.

Makes sense. Will address this and put it as last.
