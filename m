From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 17/16] net: Disable netfilter sockopts when not in the
 initial network namespace
Date: Mon, 10 Sep 2007 17:50:14 +0400
Message-ID: <46E54B96.8060105@openvz.org>
References: <m1r6l8x3vq.fsf@ebiederm.dsl.xmission.com>	<m1myvwx3sf.fsf@ebiederm.dsl.xmission.com>	<m1ir6kx3mn.fsf_-_@ebiederm.dsl.xmission.com>	<m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>	<m1abrwx3g0.fsf_-_@ebiederm.dsl.xmission.com>	<m1642kx3e3.fsf_-_@ebiederm.dsl.xmission.com>	<m11wd8x3a3.fsf_-_@ebiederm.dsl.xmission.com>	<m1sl5ovolm.fsf_-_@ebiederm.dsl.xmission.com>	<m1odgcvoje.fsf_-_@ebiederm.dsl.xmission.com>	<m1k5r0voh4.fsf_-_@ebiederm.dsl.xmission.com>	<m1fy1ovoeo.fsf_-_@ebiederm.dsl.xmission.com>	<m1bqccvock.fsf_-_@ebiederm.dsl.xmission.com>	<m17in0vo0d.fsf_-_@ebiederm.dsl.xmission.com>	<m13axovnyf.fsf_-_@ebiederm.dsl.xmission.com>	<m1y7fgu9ax.fsf_-_@ebiederm.dsl.xmission.com>	<m1tzq4u92n.fsf_-_@ebiederm.dsl.xmission.com> <m1ps0su8wv.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:36091 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751304AbXIJNxK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2007 09:53:10 -0400
In-Reply-To: <m1ps0su8wv.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Until we support multiple network namespaces with netfilter only allow
> netfilter configuration in the initial network namespace.

PATCH 17/16? :)

Sorry,
Pavel
