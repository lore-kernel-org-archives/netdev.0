From: Paul Furness <paul.furness@vil.ite.mee.com>
Subject: amd or autofos?
Date: 16 Apr 2002 13:58:38 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1018961918.1358.29.camel@x2.vil.ite.mee.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org, linux-admin@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, all.

Is there someone around with lots of experience of auto mounting nfs
shares on RedHat?

Here's the setup:
I have just taken over running the network and servers for this nice
company, and we currently have a number of servers (all running RedHat
6.2) that variously run NIS, apache, various databases, and lots of disk
space. The disks are shared using nfs shared, and then mounted using AMD
on whichever machine the user logs in to. This includes not only shared
volumes of data, but also the home directories of the users.

There is an ongoing problem where AMD on a random machine dies at a
random time, and has to be restarted so people can access files again. 

It is my intention to upgrade all the servers to RH7.2 (I could update
the individual packages and the build a kernel, but a full upgrade seems
a whole lot simpler to manage!) and I also have the chance to update how
some of it works.

So given an unrestricted choice between ams and autofs, which would you
go for? Is autofs more stable than amd? It certainly looks to be
slightly better documented and slightly easier to configure. 

Any thoughts would be appreciated.

Thanks.

BUNgle

"One of these days I'll figure how the damn thing works..."

