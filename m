From: jamal <hadi@cyberus.ca>
Subject: Re: FW: Submission for S2io 10GbE driver
Date: 23 Jan 2004 22:14:22 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1074914062.1036.39.camel@jzny.localdomain>
References: <002201c3e1f6$f97896e0$5d50ff11@S2IOtech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@s2io.com>
In-Reply-To: <002201c3e1f6$f97896e0$5d50ff11@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-01-23 at 16:22, Leonid Grossman wrote:
> Hi all,
> Please fund attached a source code for S2io 10GbE adapter (with some
> disclaimers below).
> Send me your comments/suggestions on the source please,  and we will
> address the code changes (if any) in real time.

Would be interesting to see perfomance numbers.
BTW, your specs seem to indicate two interesting features:
- Support for up to 32 concurrent PCI-X split transactions 
- Adaptive Interrupt Coalescence

can you elaborate on these?

Also indent -kr -i8 may help.

cheers,
jamal
