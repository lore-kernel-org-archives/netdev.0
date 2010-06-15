From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 3/8] sock: Introduce cred_to_ucred
Date: Tue, 15 Jun 2010 12:03:10 +0400
Message-ID: <4C1733BE.6070708@openvz.org>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org> <m139wrhxic.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Serge Hallyn <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <daniel.lezcano@free.fr>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:46711 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753638Ab0FOIE2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 04:04:28 -0400
In-Reply-To: <m139wrhxic.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2010 05:28 PM, Eric W. Biederman wrote:
> 
> To keep the coming code clear and to allow both the sock
> code and the scm code to share the logic introduce a
> fuction to translate from struct cred to struct ucred.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Acked-by: Pavel Emelyanov <xemul@openvz.org>
