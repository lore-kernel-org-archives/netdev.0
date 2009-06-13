From: Jon Smirl <jonsmirl@gmail.com>
Subject: Re: [RFC][WIP] IEEE 802.15.4 implementation for Linux v1
Date: Fri, 12 Jun 2009 23:21:34 -0400
Message-ID: <9e4733910906122021k4568df6rd80fb915b64ac12@mail.gmail.com>
References: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, slapin@ossfans.org,
	maxim.osipov@siemens.com, dmitry.baryshkov@siemens.com,
	oliver.fendt@siemens.com
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753303AbZFMDVs@vger.kernel.org>
In-Reply-To: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 1, 2009 at 10:54 AM, Dmitry
Eremin-Solenikov<dbaryshkov@gmail.com> wrote:
> Hi,
>
> As a part of research activities the Embedded Systems - Open Platform=
 Group
> from Siemens Corporate Technology we are working on adding support fo=
r
> the IEEE 802.15.4 Wireless Personal Area Networks to the Linux. Our c=
urrent
> implementation is neither certified nor even feature complete. Howeve=
r
> we'd like to present current state of our patchset to the Linux devel=
opers
> community to gain comments, fixes, ideas, etc. This is not yet a pull=
 request,
> but more like an RFC.
>
> The project page is available at http://apps.sourceforge.net/trac/lin=
ux-zigbee
> with source code of kernel part available from git at
> http://zigbee-linux.git.sourceforge.net, mirrored for convenience at
> git://git.kernel.org/pub/scm/linux/kernel/git/lumag/lowpan.git
>
> The source code for userspace utils is available from git at
> http://linux-zigbee.git.sourceforge.net/

The Zigbee alliance requires a minimum of $3,500/yr from any company
making a product based on the spec. How are you going to reconcile
this requirement with the GPL? They exempt non-commercial users but
the GPL doesn't allow code to be free for one purpose and pay for
another.

"The ZigBee Specification is available to individuals, companies and
institutions free of charge for all non-commercial purposes (including
university research, technical evaluation, and development of
non-commercial software, tools, or documentation). For ease of use,
clearly marked errata have been incorporated into this document. These
errata may not have been subjected to an Intellectual Property review,
and as such, may contain undeclared Necessary Claims. No part of this
specification may be used in development of a product for sale without
becoming a member of ZigBee Alliance. Copyright =A9 ZigBee Alliance,
Inc. (2005). All rights Reserved. This information within this
document is the property of the ZigBee Alliance and its use and
disclosure are restricted.Elements of ZigBee Alliance specifications
may be subject to third party intellectual property rights, including
without limitation, patent, copyright or trademark rights (such a
third party may or may not be a member of ZigBee). ZigBee is not
responsible and shall not be held responsible in any manner for
identifying or failing to identify any or all such third party
intellectual property rights. This document and the information
contained herein are provided on an =93AS IS=94 basis and ZigBee DISCLA=
IMS
ALL WARRANTIES EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO (A)
ANY WARRANTY THAT THE USE OF THE INFORMATION HEREIN WILL NOT INFRINGE
ANY RIGHTS OF THIRD PARTIES (INCLUDING WITH-OUT LIMITATION ANY
INTELLECTUAL PROPERTY RIGHTS INCLUDING PATENT, COPYRIGHT OR TRADEMARK
RIGHTS) OR (B) ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR
A PARTICULAR PURPOSE, TITLE OR NON-INFRINGEMENT. IN NO EVENT WILL
ZIGBEE BE LIABLE FOR ANY LOSS OF PROF-ITS, LOSS OF BUSINESS, LOSS OF
USE OF DATA, INTERRUPTION OF BUSINESS, OR FOR ANY OTHER DIRECT,
INDIRECT, SPECIAL OR EXEMPLARY, INCIDENTIAL, PUNITIVE OR CONSEQUENTIAL
DAMAGES OF ANY KIND, IN CONTRACT OR IN TORT, IN CONNECTION WITH THIS
DOCUMENT OR THE INFORMATION CONTAINED HEREIN, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH LOSS OR DAMAGE. All Company, brand and product
names may be trademarks that are the sole property of their respective
owners. <P>The above notice and this paragraph must be included on all
copies of this document that are made. ZigBee Alliance, Inc.2400
Camino Ramon, Suite 375San Ramon, CA 94583"

--=20
Jon Smirl
jonsmirl@gmail.com
