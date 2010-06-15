From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 1/8] scm: Reorder scm_cookie.
Date: Tue, 15 Jun 2010 12:00:49 +0400
Message-ID: <4C173331.4070407@openvz.org>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org> <m1d3vvhxlj.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Serge Hallyn <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <daniel.lezcano@free.fr>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:36314 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753385Ab0FOICL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 04:02:11 -0400
In-Reply-To: <m1d3vvhxlj.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2010 05:27 PM, Eric W. Biederman wrote:
> 
> Reorder the fields in scm_cookie so they pack better on 64bit.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Acked-by: Pavel Emelyanov <xemul@openvz.org>
