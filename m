From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Linux SMP on 2.4.18-3
Date: Tue, 29 Oct 2002 20:54:36 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DBF3BDC.8030902@pobox.com>
References: <Pine.GSO.4.30.0210280741020.9849-100000@shell.cyberus.ca> <3DBF3881.6070208@mc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Cheng Jin <chengjin@cs.caltech.edu>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Boris Protopopov <borisp@mc.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Boris Protopopov wrote:

> Jamal, could you give some pointers as to how "NAPIfy" a 
> 2.4.18-3/e1000-4.3.15 setup ? Boris.



In general, read Documentation/networking/NAPI_HOWTO.txt.

For e1000 specifically, copy drivers/net/e1000/*.[ch] to 2.4.x.

    Jeff
