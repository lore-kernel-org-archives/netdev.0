From: "bunty " <bunty123_4@rediffmail.com>
Subject: kernel functions in module
Date: 30 Nov 2004 08:58:59 -0000
Message-ID: <20041130085859.12552.qmail@webmail36.rediffmail.com>
Reply-To: bunty  <bunty123_4@rediffmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: netfilter-devel@lists.netfilter.org
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

  =0Ahello,=0A            can it be possible to increase size of packet in =
kernel module? If kernel source code uses skb_push,skb_pull,skb_put,skb_all=
oc etc. then can same functions be used in kernl module also?I want to incr=
ease size of packet by 8 bytes in netfilter kernel module? is there any ano=
ther approach suitable?=0Aregards,=0Aparag.
