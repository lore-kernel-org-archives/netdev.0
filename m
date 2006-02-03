From: Ian McDonald <imcdnzl@gmail.com>
Subject: Re: FW: Performance evaluation of high speed TCPs
Date: Fri, 3 Feb 2006 15:51:02 +1300
Message-ID: <cbec11ac0602021851s15442618u87eb33e783508fa7@mail.gmail.com>
References: <C0FF12BB5B83E44ABAEAA47149DA973508266A@helios.eee.strath.ac.uk>
	<C0FF12BB5B83E44ABAEAA47149DA973508266D@helios.eee.strath.ac.uk>
	<39307.60.44.142.168.1138932213.squirrel@webmail.ncsu.edu>
	<C0FF12BB5B83E44ABAEAA47149DA9735082675@helios.eee.strath.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, end2end-interest@postel.org
Return-path: <end2end-interest-bounces@postel.org>
To: Douglas Leith <doug@eee.strath.ac.uk>
In-Reply-To: <C0FF12BB5B83E44ABAEAA47149DA9735082675@helios.eee.strath.ac.uk>
Content-Disposition: inline
List-Unsubscribe: <http://www.postel.org/mailman/listinfo/end2end-interest>,
	<mailto:end2end-interest-request@postel.org?subject=unsubscribe>
List-Archive: <http://www.postel.org/pipermail/end2end-interest>
List-Post: <mailto:end2end-interest@postel.org>
List-Help: <mailto:end2end-interest-request@postel.org?subject=help>
List-Subscribe: <http://www.postel.org/mailman/listinfo/end2end-interest>,
	<mailto:end2end-interest-request@postel.org?subject=subscribe>
Sender: end2end-interest-bounces@postel.org
Errors-To: end2end-interest-bounces@postel.org
List-Id: netdev.vger.kernel.org

>  Seriously, where's the value in comparing buggy implementations - isn't
> that just a waste of all our time ?  If we are genuine about wanting to
> understand tcp performance then I think we just have to take the hit from
> issues such as this that are outside all of our control.
>
A real part of the problem here is that the Linux doesn't have a full
TCP testing suite and doesn't have build checking to check for
regressions in TCP variants. As I understand the only thing tested in
nightly builds is throughput for the default TCP.

Stephen Hemminger has done some work on TCP Probes but this is where I
think real progress could be made in improving Linux TCP. I may get
around to doing this myself at some point in my research but would
welcome other people doing it also!

Ian
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
University of Waikato
New Zealand
