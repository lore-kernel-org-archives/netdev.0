From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap
	paravirt ops callsites to make them patchable
Date: Wed, 21 Mar 2007 09:41:16 +1100
Message-ID: <1174430476.11680.123.camel@localhost.localdomain>
References: <20070316.023331.59468179.davem@davemloft.net>
	<45FB005D.9060809@goop.org>
	<1174127638.8897.75.camel@localhost.localdomain>
	<20070318.003309.71088169.davem@davemloft.net>
	<20070318120814.GA45869@muc.de>
	<1174272469.11680.23.camel@localhost.localdomain>
	<m1648xxf93.fsf@ebiederm.dsl.xmission.com>
	<Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org>
	<1174348905.11680.54.camel@localhost.localdomain>
	<45FF4043.4000805@vmware.com> <45FF770C.7050301@goop.org>
	<Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org>
	<m1mz27sy82.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Zachary Amsden <zach@vmware.com>, Jeremy Fitzhardinge <jeremy@goop.org>,
	xen-devel@lists.xensource.com, akpm@linux-foundation.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chrisw@sous-sol.org,
	Andi Kleen <ak@muc.de>, anthony@codemonkey.ws, mingo@elte.hu,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <m1mz27sy82.fsf@ebiederm.dsl.xmission.com>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Tue, 2007-03-20 at 09:58 -0600, Eric W. Biederman wrote:
> Looking at the above code snippet.  I guess it is about time to
> merge our per_cpu and pda variables...

Indeed, thanks for the prod.  Now 2.6.21-rc4-mm1 is out, I'll resend the
patches.

Cheers,
Rusty.
