From: Francesco Casadei <fr.casadei@tiscali.it>
Subject: Destroying a socket without sending FIN
Date: Wed, 06 Oct 2004 23:56:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41646A15.2010906@tiscali.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,
sorry to bother you, but I need to know how to destroy a sock structure 
from modular code without having the kernel sending FIN, i.e. a kernel 
space implementation of a close() that simply don't talk to the other 
end about what's going on. Is there a way to achieve this?

I know it may seems a little bit strange, but I need this as part of a 
research project. Please, don't be too rude with me! :-)

Best regards,

	Francesco Casadei
