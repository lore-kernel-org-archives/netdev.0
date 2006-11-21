From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch -mm] net namespace: empty framework
Date: Tue, 21 Nov 2006 19:01:03 +0100
Message-ID: <45633EDF.3050309@fr.ibm.com>
References: <4563007B.9010202@fr.ibm.com> <4563046B.6040909@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cedric Le Goater <clg@fr.ibm.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Herbert Poetzl <herbert@13thfloor.at>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Dmitry Mishin <dim@sw.ru>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1031218AbWKURBN@vger.kernel.org>
To: Kirill Korotaev <dev@sw.ru>
In-Reply-To: <4563046B.6040909@sw.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kirill Korotaev wrote:
> Cedric,
> 
> Dmitry Mishin and Daniel Lezcano are working together on the full
> network namespace incorporating both needs of OpenVZ and VServer/IBM.
> 
> Thanks,
> Kirill

Kirill,

We will need this framework to move the network isolation code to the 
ns_proxy/net_namespace structure. So if Cedric gives us a empty 
framework it is fine, except if someone does not agree with it...

   -- Daniel.
