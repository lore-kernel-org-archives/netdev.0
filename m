From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 1/6] lsm: Relocate the IPv4 security_inet_conn_request() hooks
Date: Fri, 27 Mar 2009 16:58:13 -0400
Message-ID: <200903271658.13633.paul.moore@hp.com>
References: <20090327205455.17740.61639.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	casey@schaufler-ca.com, etienne.basset@numericable.fr
To: linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:26791 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994AbZC0U6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 16:58:19 -0400
In-Reply-To: <20090327205455.17740.61639.stgit@flek.lan>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 27 March 2009 04:54:55 pm Paul Moore wrote:
> The current placement of the security_inet_conn_request() hooks do not
> allow individual LSMs to override the IP options of the connection's
> request_sock ...

My apologies, please ignore this.  I was in the process of sending a patchset 
and fat fingered the enter key.  The real patchset will follow shortly. 

-- 
paul moore
linux @ hp

