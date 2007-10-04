From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: Bugzilla: open bug reports
Date: Thu, 04 Oct 2007 13:35:13 -0400
Message-ID: <47052451.6040709@redhat.com>
References: <20071004094426.5321af0e@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58607 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755097AbXJDRfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2007 13:35:17 -0400
In-Reply-To: <20071004094426.5321af0e@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/04/2007 12:44 PM, Stephen Hemminger wrote:
> Bugzilla report of open bugs. Yes you could run it yourself but
> many of these bugs seem to be old and need some attention or work
> to get resolved.
> 
> Would this be useful to regularly run/automate?
> What format?

Yes, run it. And add links to the bugs, or at least a generic
URL at the top so people can easily find them:

  http://bugzilla.kernel.org/show_bug.cgi?id=<number>

NOTE:
In Firefox you can create "keyword" bookmarks:

  Name: Kernel Bug
  Location: http://bugzilla.kernel.org/show_bug.cgi?id=%s
  Keyword: bz

Then you can type "bz <number>" in the address bar to go right to
the bug.
