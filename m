From: Vishwanath Pai <vpai@akamai.com>
Subject: Re: [PATCH v2 1/2] libxt_hashlimit: Prepare libxt_hashlimit.c for
 revision 2
Date: Fri, 8 Jul 2016 12:54:39 -0400
Message-ID: <577FDACF.7020101@akamai.com>
References: <20160707233419.GC5026@akamai.com>
 <063D6719AE5E284EB5DD2968C1650D6D5F4F3704@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "johunt@akamai.com" <johunt@akamai.com>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pai.vishwain@gmail.com" <pai.vishwain@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"kadlec@blackhole.kfki.hu" <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:17686 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755163AbcGHQyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 12:54:41 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4F3704@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/08/2016 12:37 PM, David Laight wrote:
> If you think some users would still want 32bit limits, then you should
> (probably) use a _64 suffix for the new functions.
> 
> 	David

I am proposing a new revision for hashlimit that supports a higher rate
along with a few other changes/fixes (in separate patches). Hence the
prefix _v2 for the new functions.

- Vish
