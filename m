From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute2 PATCH v2] man: tc.8: mention available qdiscs
Date: Wed, 23 Sep 2015 16:03:19 -0700
Message-ID: <20150923160319.54d30285@urahara>
References: <20150921143048.071cea77@urahara>
	<e5ac64abda5a41a19a9557117dc0f820@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:52118 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755161AbbIWXDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 19:03:17 -0400
In-Reply-To: <e5ac64abda5a41a19a9557117dc0f820@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Sep 2015 14:18:47 +0000
Phil Sutter <phil@nwl.cc> wrote:

> Some qdiscs still lack a manpage, so listing them here is the only way
> for a user to get to know them. For the others, this serves as an
> overview of what is there.
> 
> Content was taken over from the dedicated manpage if available and
> suitable, so there is definitely room for improvement at least by
> adjusting it more to the context in which it is now. In case there
> wasn't appropriate wording available, I tried to identify key aspects of
> the given qdisc.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied, and also other documentation patches
