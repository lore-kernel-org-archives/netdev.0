From: Marc-Christian Petersen <m.c.p@wolk-project.de>
Subject: Re: [PATCH] qdisc oops fix
Date: Wed, 16 Apr 2003 20:03:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200304162003.06600.m.c.p@wolk-project.de>
References: <20030415084706.O1131@shell.cyberus.ca> <20030416160606.GA32575@louise.pinerecords.com> <3E9D8A68.5050207@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Catalin BOIE <util@deuroconsult.ro>,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>,
   Tomas Szepe <szepe@pinerecords.com>
In-Reply-To: <3E9D8A68.5050207@colorfullife.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 16 April 2003 18:52, Manfred Spraul wrote:

Hi Manfred,

> >The original backtrace as provided by Martin Volf does not contain
> >any weird addresses such as 0xd081ecc7 above:
> >http://marc.theaimsgroup.com/?l=linux-kernel&m=105013596721774&w=2
> Thanks.
> The bug was caused by sch_tree_lock() in htb_change_class().
> 2.4.21-pre7 contains a fix.
am I just blind or isn't there a fix in -pre7|current-BK?

ciao, Marc
