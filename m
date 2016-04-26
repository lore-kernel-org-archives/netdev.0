From: Quentin Monnet <quentin.monnet@6wind.com>
Subject: iproute2: bash completion function for tc
Date: Tue, 26 Apr 2016 09:28:17 +0200
Message-ID: <571F1891.1030004@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Vincent Jardin <vincent.jardin@6wind.com>, netdev@vger.kernel.org
To: Jamal Hadi Salim <hadi@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38135 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305AbcDZH2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 03:28:31 -0400
Received: by mail-wm0-f47.google.com with SMTP id u206so19356300wme.1
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 00:28:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal, Stephen,

I searched for a function providing auto-completion for `tc` utility in
bash, but I found none. So I have created one, and I would like share it
with the community. It is available here:
https://github.com/6WIND/tc_bash-completion/blob/master/tc
I would like to make it easily available to tc users, so here is a
twofold request:

* I do not know where to submit the code. Should I submit here on netdev
for inclusion in iproute2 package, or rather to the bash-completion
repository on GitHub? I feel like it would receive better feedback and
updates if pushed to iproute2. Could you please provide some advice here?
* The completion for `tc` seems to work well; I have tested it with many
commands, but I am no tc expert, and there are probably some cases where
the completion fails to propose the correct choices. I would be really
interested in any feedback/bug reports that you, or anyone on this list
who uses tc, could provide.

Best regards,
Quentin
