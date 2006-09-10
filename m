From: Dmitry Mishin <dim@openvz.org>
Subject: Re: [Devel] Re: [RFC] network namespaces
Date: Sun, 10 Sep 2006 12:11:35 +0400
Message-ID: <200609101211.35834.dim@openvz.org>
References: <20060815182029.A1685@castle.nmd.msu.ru> <20060910024709.GA13157@MAIL.13thfloor.at> <m14pvggzgw.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Herbert Poetzl <herbert@13thfloor.at>,
	Kir Kolyshkin <kir@openvz.org>, Andrey Savochkin <saw@sw.ru>,
	netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>, alexey@sw.ru,
	sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:50618 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S1750782AbWIJIM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2006 04:12:27 -0400
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m14pvggzgw.fsf@ebiederm.dsl.xmission.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 10 September 2006 07:41, Eric W. Biederman wrote:
> I certainly agree that we are not at a point where a final decision
> can be made.  A major piece of that is that a layer 2 approach has
> not shown to be without a performance penalty.
But it is required. Why to limit possible usages?
 
> A practical question.  Do the IPs assigned to guests ever get used
> by anything besides the guest?
In case of level2 virtualization - no.

-- 
Thanks,
Dmitry.
