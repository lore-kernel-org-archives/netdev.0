From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Problems in bridge.8, ip-netns.8, ip-maddress.8, ip-tunnel.8,
 ip-route.8, ip-neighbour.8, ip-rule.8
Date: Wed, 19 Jun 2013 17:53:57 -0700
Message-ID: <20130619175357.1af033aa@nehalam.linuxnetplumber.net>
References: <20130618051405.06917417E7@snark.thyrsus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: esr@thyrsus.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:54924 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934734Ab3FTAyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 20:54:02 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so5644793pdj.17
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 17:54:01 -0700 (PDT)
In-Reply-To: <20130618051405.06917417E7@snark.thyrsus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Jun 2013 01:14:05 -0400 (EDT)
esr@thyrsus.com wrote:

> This is automatically generated email about markup problems in a man
> page for which you appear to be responsible.  If you are not the right
> person or list, please tell me so I can correct my database.
> 
> See http://catb.org/~esr/doclifter/bugs.html for details on how and
> why these patches were generated.  Feel free to email me with any
> questions.  Note: These patches do not change the modification date of
> any manual page.  You may wish to do that by hand.
> 
> I apologize if this message seems spammy or impersonal. The volume of
> markup bugs I am tracking is over five hundred - there is no real
> alternative to generating bugmail from a database and template.
> 
> --
>                              Eric S. Raymond

Thank you for spotting this but please fix the formatting.

All patches should be rooted at the iproute2 top level repository 
(similar to the requirements for the
kernel as documented in Documentation/SubmittingPatches)

If apply them manually the patch fails as well. 
that can be correctly processed by git 
$ cd my-iproute2
$ cd man/man8
$ $ patch < ~/Downloads/Problems-in-bridge.8-ip-netns.8-ip-maddress.8-ip-tunnel.8-ip-route.8-ip-neighbour.8-ip-rule.8.patch 
patching file ip-rule.8
patch: **** malformed patch at line 90: Problems with ip-neighbour.8:

If you use a tool like quilt or git format-patch a correctly formatted email
will be generated.
