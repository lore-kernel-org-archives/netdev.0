From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH -mm] ne2: needs more 8390 support functions
Date: Wed, 12 Mar 2008 08:08:00 -0700
Message-ID: <47D7F1D0.1030206@oracle.com>
References: <20080311095643.01cd3708.randy.dunlap@oracle.com> <20080312124412.6089948c@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	akpm <akpm@linux-foundation.org>, jgarzik <jgarzik@pobox.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753896AbYCLQau@vger.kernel.org>
In-Reply-To: <20080312124412.6089948c@the-village.bc.nu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox wrote:
> On Tue, 11 Mar 2008 09:56:43 -0700
> Randy Dunlap <randy.dunlap@oracle.com> wrote:
> 
>> From: Randy Dunlap <randy.dunlap@oracle.com>
>>
>> ne2 (MCA) needs both 8390.o and 8390p.o functions:
> 
> NAK - the two modules are alternatives nothing should use both - is 8390p
> not sufficient ?

8390p alone is not sufficient.
http://lkml.org/lkml/2008/3/11/243

-- 
~Randy
