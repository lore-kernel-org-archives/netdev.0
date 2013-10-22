From: Daniel Wagner <wagi@monom.org>
Subject: Re: [PATCH nf-next] netfilter: xtables: lightweight process control
 group matching
Date: Tue, 22 Oct 2013 08:45:32 +0100
Message-ID: <52662D1C.2020104@monom.org>
References: <1380910855-12325-1-git-send-email-dborkman@redhat.com> <87li1qp3l8.fsf@xmission.com> <526231E0.6060903@redhat.com> <526543A2.2040901@monom.org> <52654CE6.7030706@redhat.com> <91E2D863603AD4478F101CE81E76E45D01828D59@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>
To: "Ni, Xun" <xun.ni@intel.com>, Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:33135 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178Ab3JVHpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 03:45:45 -0400
In-Reply-To: <91E2D863603AD4478F101CE81E76E45D01828D59@SHSMSX103.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Xun,

On 10/22/2013 08:15 AM, Ni, Xun wrote:
> Hello, Daniel:
> can all your examples block early before doing network operations?

I was referring to Linux Security Module which allows
to define access policies for an application e.g. which ports are
allowed to be used.

If the goal is just to block those ports you don't have to go through
half of the networking stack to figure out via an iptable rules that
this access is not allowed.

> What's the whole netfilter universe? Can you give us more clear
> examples?

I am not sure if I understood your question correctly. In case you
are asking what netfilter is I would like pointing you to the
http://www.netfilter.org/ project page.

cheers,
daniel
