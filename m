From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: how netfilter handles fragmented packets
Date: Sun, 21 Nov 2004 17:15:12 +0100 (MET)
Message-ID: <Pine.LNX.4.53.0411211714530.18608@yvahk01.tjqt.qr>
References: <20041121153154.85910.qmail@web41403.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: kernelnewbies@nl.linux.org, linux-kernel@vger.kernel.org,
   netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <kernelnewbies-bounce@nl.linux.org>
To: cranium2003 <cranium2003@yahoo.com>
In-Reply-To: <20041121153154.85910.qmail@web41403.mail.yahoo.com>
Sender: kernelnewbies-bounce@nl.linux.org
Errors-to: kernelnewbies-bounce@nl.linux.org
List-help: <mailto:ecartis@nl.linux.org?Subject=help>
List-unsubscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=unsubscribe>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=subscribe>
List-owner: <mailto:ecartis-owner@nl.linux.org>
List-post: <mailto:kernelnewbies@nl.linux.org>
List-archive: <http://mail.nl.linux.org/kernelnewbies/>
List-Id: netdev.vger.kernel.org

>hello,
>          In ip_output.c file ip_fragmet function when
>create a new fragmented packet given to output(skb)
>function. i want to know which function are actually
>called by output(skb)?

use stack_dump() (or was it dump_stack()?)



Jan Engelhardt
--=20
Gesellschaft f=C3=BCr Wissenschaftliche Datenverarbeitung
Am Fassberg, 37077 G=C3=B6ttingen, www.gwdg.de

--
Kernelnewbies: Help each other learn about the Linux kernel.
Archive:       http://mail.nl.linux.org/kernelnewbies/
FAQ:           http://kernelnewbies.org/faq/
