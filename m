From: Derek Fawcus <dfawcus@brocade.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Mon, 9 Feb 2015 11:30:53 +0000
Message-ID: <20150209113053.GB32669@dfawcus.brocade.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
 <87k2zubw7l.fsf@x220.int.ebiederm.org>
 <54D800F5.60603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	<netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	roopa <roopa@cumulusnetworks.com>, <hannes@stressinduktion.org>,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	"Vipin Kumar" <vipin@cumulusnetworks.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:31215 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759654AbbBILrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 06:47:08 -0500
Content-Disposition: inline
In-Reply-To: <54D800F5.60603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 08, 2015 at 05:36:05pm -0700, David Ahern wrote:
> To make an L3 separation efficient from a large scale* perspective one
> needs to give up something
[snip]
> 
> * scale here meaning VRFs from 1 to N, N for current products goes up to
> 4000, though I know of that has mentioned 16k VRFs.

FWIW - There is at least one router vendor which allows for the creation of
       more than 4096 VRFs.  Some of its products have a specific limitation
       which may be less than the architectural maximum.

DF
