From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: iproute2 action/policer question
Date: Wed, 17 Jun 2009 15:30:18 +0200
Message-ID: <20090617133018.GA9928@amd64.fatal.se>
References: <20090615111927.GA12316@ff.dom.local>
 <20090617061458.GA9412@ff.dom.local>
 <20090617062846.GA9764@ff.dom.local>
 <200906171201.37727.denys@visp.net.lb>
 <20090617092626.GA11005@ff.dom.local>
 <1245244194.4025.21.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	=?utf-8?B?UGF3ZcWC?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 78-82-252-13.tn.glocalnet.net ([78.82.252.13]:42116 "EHLO
	localhost" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1764717AbZFQOND (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 10:13:03 -0400
Content-Disposition: inline
In-Reply-To: <1245244194.4025.21.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On Wed, Jun 17, 2009 at 09:09:54AM -0400, jamal wrote:
[...]
> It works fine with iptables 1.4.2 for Lenny on my laptop. 
> It should work fine for the release after Lenny for 1.4.3 once
> the debian maintainers pick up the latest iproute2.

Do you mean the yet unreleased version?
The latest release, v2.6.29-1, is available in both Sid (unstable) and
Squeeze (testing) already and apparently people are having problems
with it....

[..]
> I have confidence the iptables people are more aware of the API
> breakages now than before - so very low probability it will break
> post iptables 1.4.4.
[..]

Proper .so versioning would be nice.

-- 
Andreas Henriksson
(...who only have sporadic internet access at the moment.)
