From: Michal Ostrowski <mostrows@speakeasy.net>
Subject: Re: [PATCH 2.5.72] (1/3) PPPoE cleanup [TRIVIAL]
Date: 22 Jun 2003 19:26:06 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1056324366.26751.123.camel@brick.watson.ibm.com>
References: <Mutt.LNX.4.44.0306230157140.578-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
   "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
In-Reply-To: <Mutt.LNX.4.44.0306230157140.578-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Debugging stuff can go.  I kept it in for future debugging but haven't
found it of much use.



On Sun, 2003-06-22 at 11:59, James Morris wrote:
> On Fri, 20 Jun 2003, Stephen Hemminger wrote:
> 
> > This is a cleanup patch, no change in functionality.
> >   - Get rid of debug macro's that aren't used anywhere in the code.
> 
> I'm guessing that Michal wants to leave these in for future debugging?
> 
> 
> - James
-- 
Michal Ostrowski <mostrows@speakeasy.net>
