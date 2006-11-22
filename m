From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch -mm] net namespace: empty framework
Date: Wed, 22 Nov 2006 10:55:28 +0100
Message-ID: <45641E90.2000506@fr.ibm.com>
References: <4563007B.9010202@fr.ibm.com> <4563046B.6040909@sw.ru>	<45633EDF.3050309@fr.ibm.com> <200611221121.59322.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kirill Korotaev <dev@sw.ru>, Cedric Le Goater <clg@fr.ibm.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Herbert Poetzl <herbert@13thfloor.at>,
	"Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:23877 "EHLO
	mtagate4.de.ibm.com") by vger.kernel.org with ESMTP
	id S1031346AbWKVIzj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Nov 2006 03:55:39 -0500
To: Dmitry Mishin <dim@openvz.org>
In-Reply-To: <200611221121.59322.dim@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry Mishin wrote:
> This patch looks acceptable for us.
> BTW, Daniel, we agreed to be based on the Andrey's patchset. I do not see a
> reason, why Cedric force us to make some unnecessary work and move existent
> patchset over his interface.

I still agree.
Don't blame Cedric, he just wanted to help us. BTW, it is not "his" 
interface but the namespace interface.

   -- Daniel



