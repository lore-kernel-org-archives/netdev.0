From: Jason Lunz <lunz@falooley.org>
Subject: Re: [ANNOUNCE] NAPI patches for 2.4.19-rc1
Date: Thu, 11 Jul 2002 09:26:04 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020711132604.GC12354@orr.falooley.org>
References: <20020710223237.GA7995@orr.falooley.org> <Pine.GSO.4.30.0207101917480.22734-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Robert.Olsson@data.slu.se, greearb@candelatech.com,
   garzik@mandrakesoft.com
Return-path: <owner-netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.30.0207101917480.22734-100000@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

On Wed, Jul 10, 2002 at  7:34PM -0400, jamal wrote:
> For some reason i thought there was already patches for 2.4.18 and above.
> Robert, seems like you dont have them;
> Two patches:
> 2.4.18: http://www.cyberus.ca/~hadi/patches/napi-patch-2418.gz
> 2.4.19-pre10: http://www.cyberus.ca/~hadi/patches/napi-2419-pre10.gz

ah, thanks! The napi README links to the usenix paper on your site, but
doesn't mention the patches directory.

> Also a more recently tested tulip driver at:
> http://www.cyberus.ca/~hadi/patches/tulip-napi.tgz

great, I'll check it out too.

> tested with Znyx 4 port ethernet cards; For the best perfomance (at
> least on the Znyx Nics) turn on MMIO (selected from kernel config).

Do you know if this would also apply to the DLink 4-port tulip cards
(DFE-570TX)? They're based on intel 21143's.

Jason
