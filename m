From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [PATCH] wan: kill 3 "unused" warnings
Date: Fri, 19 Sep 2003 13:48:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030919134804.2c8967e4.rddunlap@osdl.org>
References: <20030919113252.67949bc8.rddunlap@osdl.org>
	<20030919224428.A7296@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20030919224428.A7296@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 19 Sep 2003 22:44:28 +0200 Francois Romieu <romieu@fr.zoreil.com>=
 wrote:

| Randy.Dunlap <rddunlap@osdl.org> :
| [...]
| > patch_name:	dscc_warnings.patch
| > patch_version:	2003-09-19.11:18:03
| > author:		Randy.Dunlap <rddunlap@osdl.org>
| > description:	kill 3 warnings (label, functions not used);
| > product:	Linux
| > product_versions: 2.6.0-test5
| > maintainer:	Nenad Corbic <ncorbic@sangoma.com>
|=20
| ?
|=20
| $ less MAINTAINERS
| [...]
| DSCC4 DRIVER
| P:      Fran=E7ois Romieu
| M:      romieu@cogenit.fr
| M:      romieu@ensta.fr
| S:      Maintained

Ooops, sorry about that.

| The warning reminds that the call to dscc4_release_ring() is plain wron=
g
| (hmmm... as well as calling dscc4_release_ring() in dscc4_close() *doh*=
).
|=20
| Ok, I will fix this crap.

Thanks.

--
~Randy
