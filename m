From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH v2 net-next] tc: remove unused redirect ttl
Date: Fri, 1 May 2015 13:33:28 -0700
Message-ID: <CAHA+R7NOr4aQMXfC7yMuzy3dKRTJB9AYg5HMD2zVXLHM5iZYyw@mail.gmail.com>
References: <1430449896-5406-1-git-send-email-ast@plumgrid.com>
	<55435313.9030706@cogentembedded.com>
	<5543B7D6.9050508@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:34040 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728AbbEAUd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 16:33:29 -0400
Received: by wgso17 with SMTP id o17so100087296wgs.1
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 13:33:28 -0700 (PDT)
In-Reply-To: <5543B7D6.9050508@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 1, 2015 at 10:28 AM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> I don't think that's how it works. I've applied Jamal's patch
> then fixed few minor things. Therefore his SOB is on top and
> mine below. 'From' has no DCO meaning. It's used from time to time
> in merge request summary, but that's a different case.


Quote from Documentation/SubmittingPatches:

"
The "from" line must be the very first line in the message body,
and has the form:

        From: Original Author <author@example.com>

The "from" line specifies who will be credited as the author of the
patch in the permanent changelog.  If the "from" line is missing,
then the "From:" line from the email header will be used to determine
the patch author in the changelog.
"

You should take a look at how Andrew Morton works
when he fixes minor things, I am sure he fixes much
more than you do.
